# 🚀 Workshop 實作手冊：從零打造你的 Google ADK Agent

本手冊將帶你一步一步完成 Agent 的開發與部署，預計耗時 **60–90 分鐘**。

---

## 前置條件

- Python 3.11 以上
- Google Cloud 帳號（已建立專案並開啟帳單）
- 已安裝 [Google Cloud CLI (`gcloud`)](https://cloud.google.com/sdk/docs/install)
- 已安裝 Git

---

## Step 1：建立虛擬環境並安裝套件

```bash
# Clone 專案（若尚未 clone）
git clone https://github.com/LiuYuWei/google-adk-agent-template.git
cd google-adk-agent-template

# 一鍵建立虛擬環境 + 安裝套件 + 初始化 .env 範本
make setup

# 啟動虛擬環境
source .venv/bin/activate
```

> `make setup` 會自動執行：建立 `.venv`、安裝 `requirements.txt`、複製 `.env.template` 為 `.env`。

---

## Step 2：選擇你的 Agent 類型

本專案提供兩種 Agent 範本，請依需求擇一：

| Agent 類型 | 資料夾 | 適用情境 |
| :--- | :--- | :--- |
| **Gemini Agent** ⭐ 推薦 | `gemini_agent/` | 使用 Google Gemini 模型（Vertex AI） |
| **LiteLLM Agent** | `litellm_agent/` | 使用 GPT、Claude 等多種第三方模型 |

> Workshop 主要以 **`gemini_agent/`** 為主。

---

## Step 3：填寫 `.env` 環境設定

編輯 `gemini_agent/.env`，填入你的 Google Cloud 資訊：

```bash
# 用任意編輯器開啟
code gemini_agent/.env
```

填寫以下欄位：

```dotenv
# Vertex AI Configuration
GOOGLE_GENAI_USE_VERTEXAI=1
GOOGLE_CLOUD_PROJECT=your-project-id       # ← 改成你的 GCP 專案 ID
GOOGLE_CLOUD_LOCATION=us-central1

# Gemini Model Name
GEMINI_MODEL=gemini-2.5-flash
```

確認 gcloud 已登入並設定好預設專案：

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project your-project-id
```

---

## Step 4：啟動 ADK Web 介面（第一次測試）

```bash
make run
```

啟動後，在瀏覽器開啟：`http://localhost:8000`

你應該能看到 ADK 的對話介面，並與預設的 Agent 互動（預設內建 `get_current_time` 工具）。

> 確認可以正常對話後，按 `Ctrl+C` 停止伺服器，繼續下一步。

---

## Step 5：加入你自己的 Agent 工具 (Tools)

### 5-1. 在 `tools/` 資料夾新增工具函式

建立新檔案，例如 `gemini_agent/tools/my_tool.py`：

```python
def my_custom_tool(input: str) -> str:
    """
    這裡寫工具的說明。ADK 會根據這段 Docstring 決定何時呼叫此工具。

    Args:
        input: 使用者傳入的文字。

    Returns:
        str: 工具處理後回傳的結果。
    """
    # 在這裡實作你的邏輯
    return f"你輸入了：{input}"
```

> **Docstring 非常重要**，它決定了 Agent 何時、為何要呼叫這個工具。

### 5-2. 在 `agent.py` 中匯入並註冊工具

編輯 `gemini_agent/agent.py`，加入兩行：

```python
# 匯入你的新工具
from tools.my_tool import my_custom_tool

# 加入 tools 清單
root_agent = Agent(
    ...
    tools=[get_current_time, my_custom_tool]   # ← 加在這裡
)
```

---

## Step 6：重新啟動並測試新工具

```bash
make run
```

回到瀏覽器 `http://localhost:8000`，輸入對話測試你的新工具是否正常被呼叫。

> 確認沒問題後，按 `Ctrl+C` 停止伺服器，準備部署。

---

## Step 7：部署到 Google Cloud Run

### 7-1. 確認所需的 API 已啟用

```bash
gcloud services enable run.googleapis.com \
    cloudbuild.googleapis.com \
    artifactregistry.googleapis.com
```

### 7-2. 執行部署

```bash
make deploy PROJECT=your-project-id
```

> `make deploy` 使用 `adk deploy cloud_run` 指令，會自動打包並部署至 Cloud Run（含 Web UI）。
> `PROJECT` 請替換成你的 GCP 專案 ID。

### 7-3. 部署完成

部署完成後，終端機會輸出類似以下的 Service URL：

```
Service URL: https://google-adk-agent-template-xxxxxx-uc.a.run.app
```

在瀏覽器開啟該網址，即可從公開網路存取你的 Agent。

---

## 常見問題

| 問題 | 解法 |
| :--- | :--- |
| `make run` 出現 `ModuleNotFoundError` | 確認已執行 `source .venv/bin/activate` |
| Agent 無法回應，顯示認證錯誤 | 確認 `.env` 的 `GOOGLE_CLOUD_PROJECT` 正確，且已執行 `gcloud auth application-default login` |
| 工具沒有被 Agent 呼叫 | 確認 Docstring 描述清楚，且已在 `agent.py` 的 `tools=[]` 中註冊 |
| Cloud Run 部署失敗（權限不足） | 確認帳號具有 `Cloud Run Admin` 與 `Cloud Build Editor` 角色 |
| 部署後網頁打不開 | 確認部署時有加 `--with_ui` 旗標（`make deploy` 已預設包含） |
