import java.util.Arrays;

/**
 * https://stackoverflow.com/questions/127704/algorithm-to-return-all-combinations-of-k-elements-from-n
 * 
 * @since 13 de nov de 2018
 * @author Ulisses Lima
 */
public class Combine {
	public static void main(String... args) {
		int combinations = Integer.valueOf(System.getProperty("combinations", "2"));

		System.out.println("making combinations of " + combinations + " on the words " + Arrays.toString(args));

		combine(args, combinations, 0, new String[combinations]);
	}

	static void combine(String[] arr, int len, int startPosition, String[] result) {
		if (len == 0) {
			System.out.println(Arrays.toString(result));
			return;
		}
		for (int i = startPosition; i <= arr.length - len; i++) {
			result[result.length - len] = arr[i];
			combine(arr, len - 1, i + 1, result);
		}
	}
}
