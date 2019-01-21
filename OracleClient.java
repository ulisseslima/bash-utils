import java.io.PrintStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class OracleClient {
	public static void main(String[] argv) throws SQLException {
		PrintStream out = System.out;
		out.println("-------- Oracle JDBC Connection Testing ------");

		if (argv.length < 6) {
			out.println("parâmetros necessários:");
			out.println(
					"1: host, 2: porta, 3: sid/serviço no formato :<sid> ou /<service_name>, 4: usuário, 5: senha, 6: query");
			out.println();
			out.println("também é necessário especificar o caminho do driver com -cp");
			System.exit(1);
		}

		try {
			Class.forName("oracle.jdbc.driver.OracleDriver");
		} catch (Throwable e) {
			out.println("Where is your Oracle JDBC Driver? Define it with the -cp parameter");
			e.printStackTrace();
			return;
		}

		out.println("Oracle JDBC Driver Registered!");

		Connection connection = null;
		try {
			out.println("host: " + argv[0]);
			out.println("port: " + argv[1]);
			out.println("sid/service: " + argv[2]);
			out.println("user: " + argv[3]);
			out.println("pass: " + argv[4]);

			String url = "jdbc:oracle:thin:@" + argv[0] + ":" + argv[1] + argv[2];
			out.println("connection string: " + url);

			connection = DriverManager.getConnection(url, argv[3], argv[4]);
		} catch (Throwable e) {
			out.println("Connection Failed! Check output console");
			e.printStackTrace();
			return;
		}

		if (connection != null) {
			out.println("connection ok");
			String sql = argv[5];

			Statement stmt = connection.createStatement();
			out.println("command: " + sql);
			ResultSet rs = null;
			if (sql.toLowerCase().startsWith("select")) {
				rs = stmt.executeQuery(sql);

				int cols = rs.getMetaData().getColumnCount();
				for (int i = 1; i < cols + 1; i++) {
					out.print(rs.getMetaData().getColumnName(i) + "\t\t");
				}
				out.println();

				while (rs.next()) {
					for (int i = 1; i < cols + 1; i++) {
						out.print(rs.getObject(i) + "\t\t");
					}
					out.println();
				}
			} else {
				int n = stmt.executeUpdate(sql);
				out.println("rows affected: " + n);
			}
		} else {
			out.println("Failed to create a connection!");
		}
	}
}
