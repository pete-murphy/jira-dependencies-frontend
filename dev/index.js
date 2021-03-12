// require("../output/Main/index.js").main();

import React, { useEffect, useRef } from "react";
import * as d3 from "d3";
import { graphviz } from "d3-graphviz";
import ReactDOM from "react-dom";

const _ = graphviz;
_;

ReactDOM.render(<App />, document.getElementById("root"));

function App() {
  const ref = useRef(null);

  useEffect(() => {
    try {
      if (ref) {
        // d3.select(ref).graphviz().renderDot("digraph {a -> b}");
        // graphviz(`#foo`).renderDot("digraph {a -> b}");
        const x = graphviz(ref.current).dot("digraph {a -> b}");
        console.log({ x });
        x.render();
      }
    } catch (error) {
      console.error(error);
      console.warn(d3.select("#foo"));
      console.log(d3.select("#foo"));
    }
  }, []);
  return (
    <div className="App">
      <svg id="foo" width={400} height={200} ref={ref} />
    </div>
  );
}
