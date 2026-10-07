import streamlit as st

st.set_page_config(
    page_title="EDW Investigation Assistant",
    page_icon="🔎",
    layout="wide"
)

st.title("🔎 EDW Investigation Assistant")

st.write(
    "A lightweight tool for first-level investigation of "
    "EDW data quality and table dependencies."
)

st.success("Application is running successfully!")