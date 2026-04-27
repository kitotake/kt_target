/**
 * Combine class names, filtering out falsy values.
 * Usage: cx(styles.base, isActive && styles.active, "extra-class")
 */
export function cx(...classes: (string | false | null | undefined)[]): string {
  return classes.filter(Boolean).join(" ");
}
