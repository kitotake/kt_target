/**
 * FIX: @mantine/core était importé ici mais absent de package.json,
 * provoquant une erreur à l'installation. Ce provider n'est pas utilisé
 * dans l'application (App.tsx et main.tsx ne l'importent pas).
 *
 * Il est conservé comme composant stub sans dépendance externe,
 * prêt à être réactivé si @mantine/core est ajouté au projet.
 */
import React from "react";

type Props = { children: React.ReactNode };

export const ThemeProvider: React.FC<Props> = ({ children }) => (
  <>{children}</>
);