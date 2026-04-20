import os
from dotenv import load_dotenv
from google.adk.agents.llm_agent import Agent

# 1. 載入自定義工具 (Tools)
from .tools.sample_tool import get_current_time

# 2. 基礎配置
load_dotenv()

# 3. 載入模型 (Model) 與 指令 (Instruction)
from .models.litellm_model import litellm_gemma_model
from .instruction import system_instruction

# 4. 定義 ADK Root Agent
root_agent = Agent(
    name='litellm_root_agent',
    model=litellm_gemma_model,
    instruction=system_instruction,
    description='這是一個可以用來練習的通用 Agent 範本，支援多種 LLM 供應商。',
    tools=[get_current_time]
)
