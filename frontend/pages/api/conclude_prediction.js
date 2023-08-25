export default async function handler({ req, res }) {
  if (req.method == "POST") {
    const data = req.body;
    const { predictionId } = data;
  }
}
