---
title: 自定義開發
duration: 10
---

# 5. 自定義開發

ADK 的強大之處在於其結構化的開發方式。

### 修改系統指令
編輯 `gemini_agent/instruction/system.md`。
您可以嘗試將代理設定為「毒舌的工程師」或「溫柔的客服人員」，修改後重新啟動 `make run` 即可見效。

### 新增工具 (Tools)
1.  在 `gemini_agent/tools/` 下新增一個 Python 檔案，例如 `weather.py`。
2.  定義一個 function 並加上 Type Hint 與 Docstring。
3.  在 `agent.py` 中註冊該工具。

### 範例工具代碼：
```python
def get_weather(city: str):
    """取得指定城市的當前天氣。"""
    return f"{city} 的天氣是晴天，攝氏 25 度。"
```
