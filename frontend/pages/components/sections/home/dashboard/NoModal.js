import { addDecimalSixPlacesFromRight } from "@/helper/functions";
import { Button, Text, Flex } from "@chakra-ui/react";

import { useEffect, useState } from "react";

export default function NoModal({ data }) {
  const [amountNo, setAmountNo] = useState("");

  useEffect(() => {
    const temp = addDecimalSixPlacesFromRight(data["amountNo"].toString());
    console.log(temp);
    setAmountNo(temp);
  }, []);

  return (
    <>
      <Flex direction="column" align="center" gap={1}>
        <Text>Against</Text>
        <Button bgColor="red.400">{amountNo}</Button>
      </Flex>
    </>
  );
}
