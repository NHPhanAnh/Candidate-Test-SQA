export type TTemplatePlaceholder = {
  id: number;
  isActive: boolean;
  isDeleted: boolean;
  createdBy: string;
  createdAt: number;
  code: string;
  label: string;
};

export function wrapTemplateVariables(
  input: string,
  variables: TTemplatePlaceholder[],
): string {
  let result = input;
  for (const { code, label } of variables) {
    const escapedCode = code.replace(/[-/\\^$*+?.()|[\]{}]/g, "\\$&");
    const regex = new RegExp(escapedCode, "g");
    result = result.replace(regex, `<span class="chip">${label}</span>`);
  }
  return result;
}

export function parseHtmlToMergeTags(text: string) {
  let input = text;
  if (input) {
    input = input.replace(
      /<span[^>]*data-merge-tag="([^"]+)"[^>]*>.*?<\/span>/g,
      (_, code) => `\${${code}}`,
    );
  }
  return input;
}

export function parseMergeTagsToHtml(
  text: string,
  placeholders: any[],
): string {
  console.log("parse this", text);
  if (!text) return "<p></p>";

  const html = text.replace(/\$\{([A-Za-z0-9_]+)\}/g, (_, code) => {
    console.log(code);
    const p = placeholders.find((ph) => ph.code === code);
    if (!p) return `\${${code}}`;

    const attrs = [
      `data-merge-tag="${p.code}"`,
      `code="${p.code}"`,
      `data-id="${p.id}"`,
      `label="${p.label}"`,
      `id="${p.id}"`,
      `draggable="true"`,
      `class="chip"`,
    ]
      .filter(Boolean)
      .join(" ");

    return `<span ${attrs}>${p.label || p.code}</span>`;
  });

  return html;
}

export function stripCurlyBraces(input: string) {
  const stripped = input.replace(/^\$\{([^}]+)\}$/, "$1");
  return stripped;
}
