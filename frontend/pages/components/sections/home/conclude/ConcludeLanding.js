import { Box } from "@chakra-ui/react";
import ConcludeCard from "./ConcludeCard";
import { useEffect, useState } from "react";

export default function ConcludeLanding({ ids, concludedArray }) {
  const [finalArray, setFinalArray] = useState([]);

  useEffect(() => {
    async function execute() {
      const finalTemp = [];

      if (concludedArray.length == 0) setFinalArray(Object.keys(ids));
      else {
        const limit = concludedArray.length;
        for (var index = 0; index < limit; index++) {
          const element = concludedArray[index];
          if (!ids.hasOwnProperty(element)) {
            finalTemp.push(element);
          }
        }

        if (finalTemp.length != 0) setFinalArray(finalTemp);
      }
    }

    execute();
  }, []);

  return (
    <>
      {finalArray.length != 0 ? (
        <>
          <Box m={10} maxH="max-content" bgColor="#F0FFF0" borderRadius={10}>
            {finalArray.map((item, index) => (
              <ConcludeCard key={index} id={item} />
            ))}
          </Box>
        </>
      ) : null}
    </>
  );
}
