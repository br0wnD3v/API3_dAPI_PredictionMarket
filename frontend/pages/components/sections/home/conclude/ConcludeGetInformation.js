import { ApolloClient, InMemoryCache, gql } from "@apollo/client";
import { graphEndpoint } from "@/constants/info";

import { useEffect, useState } from "react";

import { toast } from "react-toastify";

import { FadeInWhenVisible } from "@/pages/components/TransitionBoxes";
import { Flex, Heading } from "@chakra-ui/react";
import ConcludeLanding from "./ConcludeLanding";

export default function ConcludeGetInformation() {
  const currentEpoch = Math.floor(Date.now() / 1000);

  const [concludedPredictions, setConcludedPredictions] = useState([]);
  const [allPredictions, setAllPredictions] = useState({});

  const predictionDetailsQuery =
    "{\n\tpredictionCreateds(orderBy: predictionId) {\n\tdeadline\n\tpredictionId\n}\n\t}";
  const concludedPredictionsQuery =
    "{\n\tpredictionConcludeds(orderBy: predictionId) {\n\tpredictionId\n}\n\t}";

  const client = new ApolloClient({
    uri: graphEndpoint,
    cache: new InMemoryCache(),
  });

  function getObject(arr) {
    const final = {};
    for (var index = 0; index < arr.length; index++) {
      if (currentEpoch >= arr[index]["deadline"])
        final[arr[index]["predictionId"]] = arr[index]["deadline"];
    }
    return final;
  }

  function getArray(arr) {
    const final = [];
    for (var index = 0; index < arr.length; index++) {
      final.push(arr[index]);
    }

    return final;
  }

  useEffect(() => {
    async function execute() {
      var { data: predictionData } = await client.query({
        query: gql`
          ${predictionDetailsQuery}
        `,
      });
      const allPredictionsArray = getObject(predictionData.predictionCreateds);
      setAllPredictions(allPredictionsArray);

      /// =======null

      var { data: concludeData } = await client.query({
        query: gql`
          ${concludedPredictionsQuery}
        `,
      });
      const concludeArray = getArray(concludeData.predictionConcludeds);
      setConcludedPredictions(concludeArray);
    }
    toast.info("Please Wait...");
    execute();
  }, []);

  return (
    <>
      {concludedPredictions.length != 0 ||
      Object.keys(allPredictions).length != 0 ? (
        <>
          <ConcludeLanding
            ids={allPredictions}
            concludedArray={concludedPredictions}
          />
        </>
      ) : (
        <>
          <FadeInWhenVisible>
            <Flex
              direction="column"
              align="center"
              justify="center"
              h={500}
              w="70%"
            >
              <Heading fontFamily="Barlow" fontSize="90px">
                It looks like there are no markets to be concluded :)
              </Heading>
            </Flex>
          </FadeInWhenVisible>
        </>
      )}
    </>
  );
}
