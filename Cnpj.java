import java.text.ParseException;
import java.util.Random;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import javax.swing.text.MaskFormatter;

/**
 * Exemplo CNPJ válido: 11.111.111/1111-80 (11111111111180)
 */
public class Cnpj {
	public static final String MASCARA = "##.###.###/####-##";
	public static final int TAMANHO_APENAS_NUMEROS = 14;

	/**
	 * @param cnpj
	 * @return verdadeiro se o cnpj for válido.
	 * @since Apr 11, 2017
	 * @author Ulisses Lima
	 */
	public static boolean validaCnpj(String cnpj) {
		if (cnpj == null || cnpj.isEmpty())
			return false;

		cnpj = removerMascara(cnpj);

		Pattern pattern = Pattern
				.compile("(\\d)(\\d)\\.?(\\d)(\\d)(\\d)\\.?(\\d)(\\d)(\\d)-?(\\d)(\\d)(\\d)(\\d)-?/?(\\d)(\\d)");
		Matcher matcher = pattern.matcher(cnpj);

		if (!matcher.matches())
			return false;

		int[] digitos = new int[15];

		for (int i = 1; i < digitos.length; i++) {
			digitos[i] = Integer.parseInt(matcher.group(i));
		}

		int resul1 = 0;
		int resul2 = 0;

		for (int i = 12; i > 4; i--)
			resul1 = (14 - i) * digitos[i] + resul1;

		for (int i = 1; i < 5; i++)
			resul1 = (6 - i) * digitos[i] + resul1;

		resul1 = resul1 % 11;

		if (resul1 == 0 || resul1 == 1)
			resul1 = 0;

		else
			resul1 = 11 - resul1;

		if (resul1 == digitos[13]) {
			for (int i = 13; i > 5; i--)
				resul2 = (15 - i) * digitos[i] + resul2;

			for (int i = 1; i < 6; i++)
				resul2 = (7 - i) * digitos[i] + resul2;

			resul2 = resul2 % 11;

			if (resul2 == 0 || resul2 == 1)
				resul2 = 0;
			else
				resul2 = 11 - resul2;

			if (resul2 == digitos[14])
				return true;
		}
		return false;
	}

	/**
	 * @param cnpj
	 * @return o cnpj com máscara.
	 * @since Aug 29, 2013
	 * @author Ulisses
	 */
	public static String aplicarMascara(String cnpj) {
		if (cnpj == null)
			return null;

		MaskFormatter mf;
		try {
			mf = new MaskFormatter(MASCARA);
			mf.setValueContainsLiteralCharacters(false);
			return mf.valueToString(cnpj);
		} catch (ParseException e) {
			return cnpj;
		}
	}

	/**
	 * @param cnpj
	 * @return o cnpj sem a máscara (apenas números)
	 * @since Aug 29, 2013
	 * @author Ulisses
	 */
	public static String removerMascara(String cnpj) {
		if (cnpj == null)
			return null;
		return cnpj.replaceAll("\\D", "");
	}

	/**
	 * @return cnpj válido.
	 * @throws Exception
	 * @since Apr 11, 2017
	 * @author Ulisses Lima
	 */
	public static String gerarCnpj() {
		int digito1 = 0, digito2 = 0, resto = 0;
		String nDigResult;
		String numerosContatenados;
		String numeroGerado;
		Random numeroAleatorio = new Random();
		// numeros gerados
		int n1 = numeroAleatorio.nextInt(10);
		int n2 = numeroAleatorio.nextInt(10);
		int n3 = numeroAleatorio.nextInt(10);
		int n4 = numeroAleatorio.nextInt(10);
		int n5 = numeroAleatorio.nextInt(10);
		int n6 = numeroAleatorio.nextInt(10);
		int n7 = numeroAleatorio.nextInt(10);
		int n8 = numeroAleatorio.nextInt(10);
		int n9 = numeroAleatorio.nextInt(10);
		int n10 = numeroAleatorio.nextInt(10);
		int n11 = numeroAleatorio.nextInt(10);
		int n12 = numeroAleatorio.nextInt(10);
		int soma = n12 * 2 + n11 * 3 + n10 * 4 + n9 * 5 + n8 * 6 + n7 * 7 + n6
				* 8 + n5 * 9 + n4 * 2 + n3 * 3 + n2 * 4 + n1 * 5;
		int valor = (soma / 11) * 11;
		digito1 = soma - valor;
		// Primeiro resto da divisão por 11.
		resto = (digito1 % 11);
		if (digito1 < 2) {
			digito1 = 0;
		} else {
			digito1 = 11 - resto;
		}
		int soma2 = digito1 * 2 + n12 * 3 + n11 * 4 + n10 * 5 + n9 * 6 + n8 * 7
				+ n7 * 8 + n6 * 9 + n5 * 2 + n4 * 3 + n3 * 4 + n2 * 5 + n1 * 6;
		int valor2 = (soma2 / 11) * 11;
		digito2 = soma2 - valor2;
		// Primeiro resto da divisão por 11.
		resto = (digito2 % 11);
		if (digito2 < 2) {
			digito2 = 0;
		} else {
			digito2 = 11 - resto;
		}
		// Concatenando os numeros
		numerosContatenados = String.valueOf(n1) + String.valueOf(n2)
				+ String.valueOf(n3) + String.valueOf(n4) + String.valueOf(n5)
				+ String.valueOf(n6) + String.valueOf(n7) + String.valueOf(n8)
				+ String.valueOf(n9) + String.valueOf(n10)
				+ String.valueOf(n11) + String.valueOf(n12);
		// Concatenando o primeiro resto com o segundo.
		nDigResult = String.valueOf(digito1) + String.valueOf(digito2);
		numeroGerado = numerosContatenados + nDigResult;
		return numeroGerado;
	}

	public static void main(String[] args) throws Exception {
		for (int i = 0; i < 10; i++) {
			String cnpj = gerarCnpj();
			boolean valido = validaCnpj(cnpj);

			System.out.println(cnpj + " - " + valido);
		}
	}
}

