import { addDecimalSixPlacesFromRightAndRemoveTrail } from "@/helper/functions";
import { Button, Text, Flex } from "@chakra-ui/react";

import { useEffect, useState } from "react";

export default function YesModal({ data }) {
  const [amountYes, setAmountYes] = useState("");

  useEffect(() => {
    const temp = addDecimalSixPlacesFromRightAndRemoveTrail(
      data["amountYes"].toString()
    );
    console.log(temp);
    setAmountYes(temp);
  }, []);

  return (
    <>
      <Flex direction="column" align="center" gap={1}>
        <Text>Favour</Text>
        <Button bgColor="green.300" _hover={{ bgColor: "green.400" }}>
          {amountYes}
        </Button>
        {amountYes.toString() != 0 ? (
          <Button fontSize="12px">Swap To Against</Button>
        ) : null}
      </Flex>
    </>
  );
}
