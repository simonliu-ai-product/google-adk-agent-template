.PHONY: venv install setup init-env run clean docker-build docker-run

# 專案設定
IMAGE_NAME = google-adk-agent-template
PORT = 8000

# 建立虛擬環境
venv:
	python3 -m venv .venv
	@echo "虛擬環境已建立。請執行 'source .venv/bin/activate' 來啟動它。"

# 安裝依賴套件
install:
	pip install -r requirements.txt

# 初始化環境變數 (.env)
init-env:
	@if [ ! -f gemini_agent/.env ]; then \
		cp gemini_agent/.env.template gemini_agent/.env; \
		echo "已建立 gemini_agent/.env"; \
	fi
	@if [ ! -f litellm_agent/.env ]; then \
		cp litellm_agent/.env.template litellm_agent/.env; \
		echo "已建立 litellm_agent/.env"; \
	fi

# 一鍵初始化環境 (建立虛擬環境、安裝套件並初始化 .env)
setup: venv init-env
	. .venv/bin/activate && pip install --upgrade pip && pip install -r requirements.txt
	@echo "初始化完成。現在您可以執行 'make run' 啟動 Agent。"

# 啟動 Agent
run:
	adk web --host 0.0.0.0 --port 8000 --allow_origins "regex:https://.*\.cloudshell\.dev"

# Docker 相關指令
docker-build: init-env
	docker build -t $(IMAGE_NAME) .

docker-run:
	docker run -p $(PORT):$(PORT) --env-file gemini_agent/.env $(IMAGE_NAME)

# 清理快取檔案
clean:
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	rm -rf .adk/
