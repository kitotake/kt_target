import React from "react";
import { MantineProvider, createTheme } from "@mantine/core";

const theme = createTheme({
  fontFamily: "Nunito, sans-serif",
  shadows: { sm: "1px 1px 3px rgba(0, 0, 0, 0.5)" },
  components: {
    Button: {
      styles: {
        root: { border: "none" },
      },
    },
  },
});

type Props = { children: React.ReactNode };

export const ThemeProvider: React.FC<Props> = ({ children }) => (
  <MantineProvider theme={theme} defaultColorScheme="dark">
    {children}
  </MantineProvider>
);