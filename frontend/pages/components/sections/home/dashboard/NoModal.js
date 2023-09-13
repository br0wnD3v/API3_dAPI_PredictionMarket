import { addDecimalSixPlacesFromRightAndRemoveTrail } from "@/helper/functions";
import { Button, Text, Flex } from "@chakra-ui/react";

import { useEffect, useState } from "react";

export default function NoModal({ data }) {
  const [amountNo, setAmountNo] = useState("");

  useEffect(() => {
    const temp = addDecimalSixPlacesFromRightAndRemoveTrail(
      data["amountNo"].toString()
    );
    console.log(temp);
    setAmountNo(temp);
  }, []);

  return (
    <>
      <Flex direction="column" align="center" gap={1}>
        <Text>Against</Text>
        <Button bgColor="red.300" _hover={{ bgColor: "red.400" }}>
          {amountNo}
        </Button>
        {amountNo.toString() != 0 ? (
          <Button fontSize="12px">Swap To Favour</Button>
        ) : null}
      </Flex>
    </>
  );
}
