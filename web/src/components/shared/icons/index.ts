export const Icons = {
  car:       "fa-solid fa-car",
  carSide:   "fa-solid fa-car-side",
  carRear:   "fa-solid fa-car-rear",
  wrench:    "fa-solid fa-wrench",
  rotate:    "fa-solid fa-rotate",
  cube:      "fa-solid fa-cube",
  info:      "fa-solid fa-circle-info",
  trash:     "fa-solid fa-trash",
  snowflake: "fa-solid fa-snowflake",
  move:      "fa-solid fa-up-down-left-right",
  user:      "fa-solid fa-user",
  ban:       "fa-solid fa-ban",
  handWave:  "fa-solid fa-hand-wave",
  hand:      "fa-solid fa-hand-pointer",
  mapPin:    "fa-solid fa-map-pin",
  heartbeat: "fa-solid fa-heart-pulse",
  cloud:     "fa-solid fa-cloud-sun",
  tool:      "fa-solid fa-screwdriver-wrench",
} as const;

export type IconKey = keyof typeof Icons;
