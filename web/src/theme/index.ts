/**
 * FIX: @mantine/core était importé ici mais absent de package.json.
 * Ce fichier est conservé vide pour maintenir la structure du projet.
 * Pour réactiver Mantine, ajouter @mantine/core et @mantine/hooks dans
 * package.json puis décommenter le contenu ci-dessous.
 */

// import { createTheme } from "@mantine/core";
//
// export const theme = createTheme({
//   fontFamily: "Nunito, sans-serif",
//   shadows: { sm: "1px 1px 3px rgba(0, 0, 0, 0.5)" },
//   components: {
//     Button: {
//       styles: {
//         root: { border: "none" },
//       },
//     },
//   },
// });

export const theme = {} as const;