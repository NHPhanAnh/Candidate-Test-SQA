import {
  DEFAULT_MONOGRAM_BACKGROUND_COLOR,
  DEFAULT_MONOGRAM_TEXT,
  MONOGRAM_BACKGROUND_COLOR,
} from "~/const/user";

const getMonogramColor = (id: number | undefined): string => {
  if (!id) {
    return DEFAULT_MONOGRAM_BACKGROUND_COLOR;
  }
  const colors = MONOGRAM_BACKGROUND_COLOR;
  const monogramColor =
    colors[id % colors.length] || DEFAULT_MONOGRAM_BACKGROUND_COLOR;
  return monogramColor;
};

const getMonogramText = (name: string | null | undefined) => {
  if (!name) {
    return DEFAULT_MONOGRAM_TEXT;
  }
  const names = name?.split(/\s+/);
  let _name = "";
  if (names && names.length) {
    if (names[0]) {
      _name += names[0][0];
    }
    if (names[1]) {
      _name += names[1][0];
    }
    if (_name.length) {
      return _name;
    }
  }
  return DEFAULT_MONOGRAM_TEXT;
};

const getMonogram = (id: number, name: string) => {
  const color = getMonogramColor(id);
  const text = getMonogramText(name);

  return {
    color,
    text,
  };
};

export { getMonogramColor, getMonogramText, getMonogram };
