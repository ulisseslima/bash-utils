import java.text.ParseException;
import java.util.Random;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.swing.text.MaskFormatter;

/**
 * Exemplos CPF válidos:
 * <p>
 * 123.456.789-09 (12345678909)<br>
 * 123.123.123-87 (12312312387)<br>
 * 111.222.333-96 (11122233396)
 */
public class Cpf {
	public static final String MASCARA = "###.###.###-##";
	public static final int TAMANHO_APENAS_NUMEROS = 11;

	public static boolean validaCpf(String cpf) {
		if (cpf == null || cpf.isEmpty())
			return false;

		Pattern pattern = Pattern
				.compile("(\\d)(\\d)(\\d)\\.?(\\d)(\\d)(\\d)\\.?(\\d)(\\d)(\\d)-?(\\d)(\\d)");
		Matcher matcher = pattern.matcher(cpf);

		if (!matcher.matches())
			return false;

		int[] digitos = new int[11];

		for (int i = 0; i < digitos.length; i++) {
			digitos[i] = Integer.parseInt(matcher.group(i + 1));
		}

		int resul1 = 0;
		int resul2 = 0;

		for (int i = 0; i < 9; i++)
			resul1 = (10 - i) * digitos[i] + resul1;

		resul1 = resul1 % 11;

		if (resul1 == 0 || resul1 == 1)
			resul1 = 0;
		else
			resul1 = 11 - resul1;

		if (resul1 == digitos[9]) {
			for (int i = 0; i < 10; i++)
				resul2 = (11 - i) * digitos[i] + resul2;

			resul2 = resul2 % 11;

			if (resul2 == 0 || resul2 == 1)
				resul2 = 0;
			else
				resul2 = 11 - resul2;

			if (resul2 == digitos[10])
				return true;
		}
		return false;
	}

	/**
	 * @return um CPF aleatório e válido.
	 * @since Jan 15, 2015
	 * @author Ulisses
	 */
	public static String gerarCpf() {
		int digito1 = 0, digito2 = 0, resto = 0;
		String nDigResult;
		String numerosContatenados;
		String numeroGerado;
		Random numeroAleatorio = new Random();
		// números gerados
		int n1 = numeroAleatorio.nextInt(10);
		int n2 = numeroAleatorio.nextInt(10);
		int n3 = numeroAleatorio.nextInt(10);
		int n4 = numeroAleatorio.nextInt(10);
		int n5 = numeroAleatorio.nextInt(10);
		int n6 = numeroAleatorio.nextInt(10);
		int n7 = numeroAleatorio.nextInt(10);
		int n8 = numeroAleatorio.nextInt(10);
		int n9 = numeroAleatorio.nextInt(10);
		int soma = n9 * 2 + n8 * 3 + n7 * 4 + n6 * 5 + n5 * 6 + n4 * 7 + n3 * 8
				+ n2 * 9 + n1 * 10;
		int valor = (soma / 11) * 11;
		digito1 = soma - valor;
		// Primeiro resto da divisão por 11.
		resto = (digito1 % 11);
		if (digito1 < 2) {
			digito1 = 0;
		} else {
			digito1 = 11 - resto;
		}
		int soma2 = digito1 * 2 + n9 * 3 + n8 * 4 + n7 * 5 + n6 * 6 + n5 * 7
				+ n4 * 8 + n3 * 9 + n2 * 10 + n1 * 11;
		int valor2 = (soma2 / 11) * 11;
		digito2 = soma2 - valor2;
		// Primeiro resto da divisão por 11.
		resto = (digito2 % 11);
		if (digito2 < 2) {
			digito2 = 0;
		} else {
			digito2 = 11 - resto;
		}
		// Concatenando os números
		numerosContatenados = String.valueOf(n1) + String.valueOf(n2)
				+ String.valueOf(n3) + String.valueOf(n4) + String.valueOf(n5)
				+ String.valueOf(n6) + String.valueOf(n7) + String.valueOf(n8)
				+ String.valueOf(n9);

		// Concatenando o primeiro resto com o segundo.
		nDigResult = String.valueOf(digito1) + String.valueOf(digito2);
		numeroGerado = numerosContatenados + nDigResult;
		return numeroGerado;
	}

	/**
	 * @param cpf
	 * @return o cpf com máscara.
	 * @since Aug 29, 2013
	 * @author Ulisses
	 */
	public static String aplicarMascara(String cpf) {
		if (cpf == null)
			return null;

		MaskFormatter mf;
		try {
			mf = new MaskFormatter(MASCARA);
			mf.setValueContainsLiteralCharacters(false);
			return mf.valueToString(cpf);
		} catch (ParseException e) {
			return cpf;
		}
	}

	/**
	 * @param cpf
	 * @return o cpf sem a máscara (apenas números)
	 * @since Aug 29, 2013
	 * @author Ulisses
	 */
	public static String removerMascara(String cpf) {
		if (cpf == null)
			return null;
		return cpf.replaceAll("\\D", "");
	}

	public static void main(String[] args) {
		for (int i = 0; i < 10; i++) {
			String cpf = gerarCpf();
			boolean valido = validaCpf(cpf);

			System.out.println(cpf + " - " + valido);
		}
	}
}

