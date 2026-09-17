"""Streamlit ChatGPT-style UI backed by OpenAI through LangChain."""

import os

import httpx
import streamlit as st
from dotenv import load_dotenv
from langchain_core.messages import AIMessage, HumanMessage
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_openai import ChatOpenAI

load_dotenv()

st.set_page_config(
    page_title="OpenAI Chatbot",
    page_icon="🤖",
    layout="centered",
)

SYSTEM_MESSAGE = (
    "You are a helpful assistant. Answer clearly and accurately. "
    "Use the conversation history when it is relevant. "
    "If you do not know something, say so instead of inventing an answer."
)

MODEL_OPTIONS = [
    "gpt-4o-mini",
    "gpt-4.1-mini",
    "gpt-4o",
    "Custom...",
]

# Required for this network environment, which presents a certificate that
# the local Python trust store cannot validate.
SSL_VERIFY = False


def build_chain(api_key: str, model_name: str, temperature: float, max_tokens: int, ssl_verify):
    """Build a fresh LangChain pipeline using the current sidebar settings."""
    http_client = httpx.Client(verify=ssl_verify, timeout=60)
    llm = ChatOpenAI(
        api_key=api_key,
        model=model_name,
        temperature=temperature,
        max_tokens=max_tokens,
        max_retries=2,
        timeout=60,
        http_client=http_client,
    )
    prompt = ChatPromptTemplate.from_messages([
        ("system", SYSTEM_MESSAGE),
        MessagesPlaceholder(variable_name="chat_history"),
        ("human", "{question}"),
    ])
    return prompt | llm | StrOutputParser(), http_client


def to_langchain_messages(messages):
    """Convert session-state dictionaries into LangChain chat messages."""
    history = []
    for message in messages:
        if message["role"] == "user":
            history.append(HumanMessage(content=message["content"]))
        elif message["role"] == "assistant":
            history.append(AIMessage(content=message["content"]))
    return history


if "messages" not in st.session_state:
    st.session_state.messages = []

with st.sidebar:
    st.header("Model Configuration")

    openai_api_key = st.text_input(
        "OpenAI API Key",
        value=os.getenv("OPENAI_API_KEY", ""),
        type="password",
        help="Your key is used only for requests from this app.",
    )

    selected_model = st.selectbox("OpenAI model", MODEL_OPTIONS, index=0)
    custom_model = ""
    if selected_model == "Custom...":
        custom_model = st.text_input("Custom model ID", placeholder="gpt-4o-mini")

    temperature = st.slider(
        "Temperature",
        min_value=0.0,
        max_value=2.0,
        value=0.7,
        step=0.1,
        help="Higher values make responses more varied.",
    )
    max_tokens = st.slider(
        "Maximum output tokens",
        min_value=64,
        max_value=4096,
        value=512,
        step=64,
    )

    if st.button("Clear chat", use_container_width=True):
        st.session_state.messages = []
        st.rerun()

st.title("🤖 OpenAI Chatbot")
st.caption("A LangChain chat with persistent conversation history")

for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

question = st.chat_input("Message the assistant...")

if question:
    if not openai_api_key.strip():
        st.warning("Enter your OpenAI API key in the sidebar first.")
        st.stop()

    model_name = custom_model.strip() if selected_model == "Custom..." else selected_model
    if not model_name:
        st.warning("Enter a custom model ID first.")
        st.stop()

    history = to_langchain_messages(st.session_state.messages)
    st.session_state.messages.append({"role": "user", "content": question})

    with st.chat_message("user"):
        st.markdown(question)

    chain, http_client = build_chain(
        api_key=openai_api_key.strip(),
        model_name=model_name,
        temperature=temperature,
        max_tokens=max_tokens,
        ssl_verify=SSL_VERIFY,
    )

    try:
        with st.chat_message("assistant"):
            with st.spinner("Thinking..."):
                answer = chain.invoke({"chat_history": history, "question": question})
            st.markdown(answer)

        st.session_state.messages.append({"role": "assistant", "content": answer})
    except Exception as error:
        st.error(f"Could not generate a response: {type(error).__name__}: {error}")
        st.session_state.messages.pop()
    finally:
        http_client.close()
