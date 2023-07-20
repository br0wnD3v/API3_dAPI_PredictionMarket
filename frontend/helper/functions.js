export function addDecimalTwoPlacesFromRight(inputString) {
  const length = inputString.length;
  if (length <= 2) {
    // If the length is less than or equal to 2, simply return the string as it is.
    return inputString;
  } else {
    // Insert the decimal point at the appropriate position and return the modified string.
    const modifiedString =
      inputString.slice(0, length - 2) + "." + inputString.slice(length - 2);
    return modifiedString;
  }
}
