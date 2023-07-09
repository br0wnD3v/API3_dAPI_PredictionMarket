import { Box } from "@chakra-ui/react";
import { CircularProgress } from "@chakra-ui/react";

import { useAccount } from "wagmi";

import HeroHome from "./Hero/Home";

export default function HomeHero({ page }) {
  const { isConnected } = useAccount();

  return (
    <>
      <Box align="center">
        {!isConnected ? (
          <>
            <CircularProgress
              mt={200}
              isIndeterminate
              color="blue.700"
              thickness="5px"
              size="100px"
            />
          </>
        ) : (
          <>
            {page == "Home" ? (
              <>
                <HeroHome />
              </>
            ) : page == "Create" ? (
              <>Create</>
            ) : (
              <>Buy</>
            )}
          </>
        )}
      </Box>
    </>
  );
}
