package com.example.crudwithvaadin;

import com.vaadin.flow.component.button.Button;
import com.vaadin.flow.component.orderedlayout.VerticalLayout;
import com.vaadin.flow.component.textfield.TextArea;
import com.vaadin.flow.router.Route;
import org.springframework.beans.factory.annotation.Autowired;

import javax.sql.DataSource;
import java.sql.*;

@Route("psql-terminal")
public class PsqlTerminalView extends VerticalLayout {

    private final DataSource dataSource;

    private final TextArea queryArea = new TextArea("SQL Query");
    private final Button runButton = new Button("Run");
    private final TextArea resultArea = new TextArea("Result");

    @Autowired
    public PsqlTerminalView(DataSource dataSource) {
        this.dataSource = dataSource;
        queryArea.setWidthFull();
        queryArea.setHeight("250px"); // Increased height
        resultArea.setWidthFull();
        resultArea.setHeight("300px");
        resultArea.setReadOnly(true);

        runButton.addClickListener(e -> runQuery());

        add(queryArea, runButton, resultArea);
    }

    private void runQuery() {
        String sql = queryArea.getValue();
        if (sql == null || sql.trim().isEmpty()) {
            resultArea.setValue("Please enter a SQL query.");
            return;
        }
        try (Connection conn = dataSource.getConnection();
             Statement stmt = conn.createStatement()) {
            boolean hasResultSet = stmt.execute(sql);
            if (hasResultSet) {
                try (ResultSet rs = stmt.getResultSet()) {
                    resultArea.setValue(resultSetToString(rs));
                }
            } else {
                int updateCount = stmt.getUpdateCount();
                resultArea.setValue("Update count: " + updateCount);
            }
        } catch (SQLException ex) {
            resultArea.setValue("Error: " + ex.getMessage());
        }
    }

    private String resultSetToString(ResultSet rs) throws SQLException {
        StringBuilder sb = new StringBuilder();
        ResultSetMetaData meta = rs.getMetaData();
        int colCount = meta.getColumnCount();
        // Header
        for (int i = 1; i <= colCount; i++) {
            sb.append(meta.getColumnName(i)).append("\t");
        }
        sb.append("\n");
        // Rows
        while (rs.next()) {
            for (int i = 1; i <= colCount; i++) {
                sb.append(rs.getString(i)).append("\t");
            }
            sb.append("\n");
        }
        return sb.toString();
    }
}