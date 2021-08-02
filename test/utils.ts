export function toZeroX(x: string) {
  return "0x" + x;
}
export function mutateOneChar(str: string, index: number, char: string) {
  return str.substr(0, index) + char + str.substr(index + 1);
}
