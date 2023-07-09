import HomeHeader from "./HomeHeader";
import HomeHero from "./HomeHero";
import { useState } from "react";

export default function HomeLayout() {
  const [page, setPage] = useState("Home");

  return (
    <>
      <HomeHeader setPage={setPage} />
      <HomeHero page={page} />
    </>
  );
}
