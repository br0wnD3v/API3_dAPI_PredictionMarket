import { useEffect, useState } from "react";
import { ApolloClient, InMemoryCache, gql } from "@apollo/client";

import { graphEndpoint } from "@/information/constants";

import { toast } from "react-toastify";

import BuyLanding from "./BuyLanding";

export default function BuyGetInformation() {
  const [dataFetched, setDataFetched] = useState(null);
  const [length, setLength] = useState(0);
  const [ids, setIds] = useState(null);
  const [graphDataFetched, setGraphDataFetched] = useState(null);

  const currentTime = Date.now();
  const unixEpoch = Math.floor(currentTime / 1000);
  const queryFinal = `query AvailableMarkets\n{\n  predictionCreateds(orderBy: deadline, where: {deadline_gt: ${unixEpoch}}) {\n  marketHandler\n  predictionId\n  }\n}`;

  const client = new ApolloClient({
    uri: graphEndpoint,
    cache: new InMemoryCache(),
  });

  useEffect(() => {
    if (length > 0) {
      setDataFetched(true);
    }
  }, [length]);

  useEffect(() => {
    if (ids && ids.length >= 1) {
      setLength(ids.length);
    }
  }, [ids]);

  useEffect(() => {
    var idsArray = [];
    if (graphDataFetched) {
      for (let key in graphDataFetched) {
        idsArray.push(graphDataFetched[key]["predictionId"]);
      }
    }
    if (typeof idsArray != null) {
      setIds(idsArray);
    }
  }, [graphDataFetched]);

  useEffect(() => {
    async function execute() {
      var { data } = await client.query({
        query: gql`
          ${queryFinal}
        `,
      });
      const finalArray = data.predictionCreateds;
      setGraphDataFetched(finalArray);
    }
    toast.info("Sit back and relax while we fetch recent details :) ...");
    execute();
  }, []);

  return (
    <>
      {dataFetched && ids && length ? (
        <BuyLanding ids={ids} length={length} />
      ) : null}
    </>
  );
}
