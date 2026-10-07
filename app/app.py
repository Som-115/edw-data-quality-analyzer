import streamlit as st
import pandas as pd

from db import get_connection
from queries import (
    TABLE_LIST_QUERY,
    COLUMN_COUNT_QUERY,
    PRIMARY_KEY_QUERY,
    HEALTH_QUERY,
    DQ_RESULTS_QUERY,
    IMPACT_ANALYSIS_QUERY,
)


st.set_page_config(
    page_title="EDW Investigation Assistant",
    page_icon="🔎",
    layout="wide",
)


st.title("🔎 EDW Investigation Assistant")

st.write(
    "A lightweight tool for first-level investigation of "
    "EDW data quality and table dependencies."
)


# ============================================================
# GET TABLES
# ============================================================

def get_tables(conn):
    cursor = conn.cursor()

    try:
        cursor.execute(TABLE_LIST_QUERY)

        tables = [
            row[0]
            for row in cursor.fetchall()
        ]

        return tables

    finally:
        cursor.close()


# ============================================================
# GET ROW COUNT
# ============================================================

def get_table_row_count(conn, table_name):
    cursor = conn.cursor()

    try:
        query = f"""
        SELECT COUNT(*)
        FROM dbo.{table_name};
        """

        cursor.execute(query)

        return cursor.fetchone()[0]

    finally:
        cursor.close()


# ============================================================
# GET COLUMN COUNT
# ============================================================

def get_column_count(conn, table_name):
    cursor = conn.cursor()

    try:
        cursor.execute(
            COLUMN_COUNT_QUERY,
            table_name,
        )

        return cursor.fetchone()[0]

    finally:
        cursor.close()


# ============================================================
# GET PRIMARY KEY
# ============================================================

def get_primary_key(conn, table_name):
    cursor = conn.cursor()

    try:
        cursor.execute(
            PRIMARY_KEY_QUERY,
            table_name,
        )

        primary_keys = [
            row[0]
            for row in cursor.fetchall()
        ]

        if primary_keys:
            return ", ".join(primary_keys)

        return "None"

    finally:
        cursor.close()


# ============================================================
# GET HEALTH
# ============================================================

def get_health(conn, table_name):
    cursor = conn.cursor()

    try:
        cursor.execute(
            HEALTH_QUERY,
            table_name,
        )

        row = cursor.fetchone()

        total_checks = row[0] or 0
        passed_checks = row[1] or 0
        failed_checks = row[2] or 0
        total_issues = row[3] or 0
        deduction = row[4] or 0

        health_score = max(
            0,
            100 - deduction,
        )

        if health_score >= 90:
            status = "HEALTHY"

        elif health_score >= 75:
            status = "GOOD"

        elif health_score >= 50:
            status = "NEEDS_ATTENTION"

        else:
            status = "CRITICAL"

        return (
            health_score,
            status,
            total_checks,
            passed_checks,
            failed_checks,
            total_issues,
        )

    finally:
        cursor.close()


# ============================================================
# GET DATA QUALITY RESULTS
# ============================================================

def get_dq_results(conn, table_name):
    cursor = conn.cursor()

    try:
        cursor.execute(
            DQ_RESULTS_QUERY,
            table_name,
        )

        columns = [
            column[0]
            for column in cursor.description
        ]

        rows = [
            tuple(row)
            for row in cursor.fetchall()
        ]

        return rows, columns

    finally:
        cursor.close()


# ============================================================
# GET IMPACT ANALYSIS
# ============================================================

def get_impact_analysis(conn, table_name):
    cursor = conn.cursor()

    try:
        cursor.execute(
            IMPACT_ANALYSIS_QUERY,
            table_name,
        )

        columns = [
            column[0]
            for column in cursor.description
        ]

        rows = [
            tuple(row)
            for row in cursor.fetchall()
        ]

        return rows, columns

    finally:
        cursor.close()


# ============================================================
# MAIN APPLICATION
# ============================================================

try:

    # Reuse cached Fabric connection
    conn = get_connection()

    tables = get_tables(conn)

    if tables:

        # ========================================================
        # TABLE SELECTION
        # ========================================================

        selected_table = st.selectbox(
            "Select a table to investigate",
            tables,
        )

        st.success(
            f"Connected successfully. "
            f"Selected table: {selected_table}"
        )

        st.divider()

        # ========================================================
        # TABLE OVERVIEW
        # ========================================================

        st.subheader("📊 Table Overview")

        row_count = get_table_row_count(
            conn,
            selected_table,
        )

        column_count = get_column_count(
            conn,
            selected_table,
        )

        primary_key = get_primary_key(
            conn,
            selected_table,
        )

        (
            health_score,
            health_status,
            total_checks,
            passed_checks,
            failed_checks,
            total_issues,
        ) = get_health(
            conn,
            selected_table,
        )

        col1, col2, col3, col4 = st.columns(4)

        with col1:

            st.metric(
                "Total Rows",
                row_count,
            )

        with col2:

            st.metric(
                "Columns",
                column_count,
            )

        with col3:

            st.metric(
                "Primary Key",
                primary_key,
            )

        with col4:

            st.metric(
                "Health Score",
                f"{health_score} / 100",
            )

        # ========================================================
        # HEALTH STATUS
        # ========================================================

        st.subheader("Health Status")

        if health_status == "HEALTHY":

            st.success(
                f"🟢 {health_status}"
            )

        elif health_status == "GOOD":

            st.info(
                f"🟢 {health_status}"
            )

        elif health_status == "NEEDS_ATTENTION":

            st.warning(
                f"🟠 {health_status}"
            )

        else:

            st.error(
                f"🔴 {health_status}"
            )

        st.write(
            f"Checks: **{total_checks}**  |  "
            f"Passed: **{passed_checks}**  |  "
            f"Failed: **{failed_checks}**  |  "
            f"Issues: **{total_issues}**"
        )

        # ========================================================
        # DATA QUALITY INVESTIGATION
        # ========================================================

        st.divider()

        st.subheader(
            "🔍 Data Quality Investigation"
        )

        dq_rows, dq_columns = get_dq_results(
            conn,
            selected_table,
        )

        dq_df = None

        if dq_rows:

            dq_df = pd.DataFrame.from_records(
                dq_rows,
                columns=dq_columns,
            )

            st.dataframe(
                dq_df,
                use_container_width=True,
                hide_index=True,
            )

        else:

            st.success(
                "No data quality checks have been "
                "executed for this table."
            )

        # ========================================================
        # IMPACT ANALYSIS
        # ========================================================

        st.divider()

        st.subheader("🔗 Impact Analysis")

        impact_rows, impact_columns = get_impact_analysis(
            conn,
            selected_table,
        )

        impact_df = None

        if impact_rows:

            impact_df = pd.DataFrame.from_records(
                impact_rows,
                columns=impact_columns,
            )

            # ----------------------------------------------------
            # SUMMARY COUNTS
            # ----------------------------------------------------

            upstream_count = sum(
                1
                for row in impact_rows
                if row[0] == "UPSTREAM"
            )

            downstream_count = sum(
                1
                for row in impact_rows
                if row[0] == "DOWNSTREAM"
            )

            col1, col2 = st.columns(2)

            with col1:

                st.metric(
                    "Upstream Relationships",
                    upstream_count,
                )

            with col2:

                st.metric(
                    "Downstream Relationships",
                    downstream_count,
                )

            st.dataframe(
                impact_df,
                use_container_width=True,
                hide_index=True,
            )

        else:

            upstream_count = 0
            downstream_count = 0

            st.info(
                "No upstream or downstream relationships "
                "were found for this table."
            )

        # ========================================================
        # INVESTIGATION SUMMARY
        # ========================================================

        st.divider()

        st.subheader("🧭 Investigation Summary")

        # --------------------------------------------------------
        # Build summary message
        # --------------------------------------------------------

        if health_status == "HEALTHY":

            summary_icon = "🟢"

            health_message = (
                f"{selected_table} is healthy with a "
                f"health score of {health_score}/100."
            )

        elif health_status == "GOOD":

            summary_icon = "🟢"

            health_message = (
                f"{selected_table} has a good health status "
                f"with a health score of {health_score}/100."
            )

        elif health_status == "NEEDS_ATTENTION":

            summary_icon = "🟠"

            health_message = (
                f"{selected_table} requires attention with a "
                f"health score of {health_score}/100."
            )

        else:

            summary_icon = "🔴"

            health_message = (
                f"{selected_table} is in a critical state with a "
                f"health score of {health_score}/100."
            )

        st.markdown(
            f"### {summary_icon} {health_message}"
        )

        # --------------------------------------------------------
        # DQ summary
        # --------------------------------------------------------

        if dq_df is not None and not dq_df.empty:

            failed_checks_list = dq_df[
                dq_df["Status"] == "FAIL"
            ]

            failed_check_count = len(
                failed_checks_list
            )

            total_issue_count = int(
                dq_df["IssueCount"].fillna(0).sum()
            )

            st.warning(
                f"⚠️ {failed_check_count} data-quality "
                f"check(s) failed, resulting in "
                f"{total_issue_count} issue(s)."
            )

            # Show individual failed checks
            for _, row in failed_checks_list.iterrows():

                column_name = row["ColumnName"]
                rule_name = row["RuleName"]
                issue_count = row["IssueCount"]

                st.write(
                    f"• **{rule_name}** on "
                    f"`{column_name}` — "
                    f"{issue_count} issue(s)"
                )

        else:

            st.success(
                "✅ No data-quality issues were detected."
            )

        # --------------------------------------------------------
        # Impact summary
        # --------------------------------------------------------

        if downstream_count > 0:

            st.info(
                f"🔗 The table has **{upstream_count}** "
                f"upstream relationship(s) and "
                f"**{downstream_count}** downstream "
                f"relationship(s)."
            )

            st.warning(
                f"⚠️ {downstream_count} downstream table(s) "
                f"may be affected by changes to "
                f"`{selected_table}`."
            )

        elif upstream_count > 0:

            st.info(
                f"🔗 The table has **{upstream_count}** "
                f"upstream relationship(s) and no "
                f"identified downstream relationships."
            )

        else:

            st.info(
                "🔗 No upstream or downstream relationships "
                "were identified."
            )

        # --------------------------------------------------------
        # Final interpretation
        # --------------------------------------------------------

        st.markdown("### 📌 Investigation Result")

        if (
            health_status in ["NEEDS_ATTENTION", "CRITICAL"]
            and total_issues > 0
            and downstream_count > 0
        ):

            st.error(
                f"⚠️ **Action recommended:** "
                f"{selected_table} has data-quality issues "
                f"and downstream dependencies. "
                f"Investigate the failed checks before making "
                f"changes that could affect dependent tables."
            )

        elif total_issues > 0:

            st.warning(
                f"⚠️ **Action recommended:** "
                f"Review the {total_issues} detected "
                f"data-quality issue(s) in {selected_table}."
            )

        elif downstream_count > 0:

            st.info(
                f"ℹ️ **Impact consideration:** "
                f"{selected_table} has downstream dependencies. "
                f"Review dependent tables before making structural "
                f"or data changes."
            )

        else:

            st.success(
                f"✅ **No immediate investigation concerns "
                f"were identified for {selected_table}.**"
            )

    else:

        st.warning(
            "No tables found in the dbo schema."
        )


except Exception as e:

    st.error(
        "Unable to load table information."
    )

    st.exception(e)