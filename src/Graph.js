const React = require("react");
const { graphviz } = require("d3-graphviz");

const _ = graphviz;
_;

exports._mkGraph = function () {
  console.log("Here");
  return function ({ graphString }) {
    const ref = React.useRef(null);
    console.log("and here now");
    React.useEffect(() => {
      console.log({ graphString });
      try {
        if (ref && graphString) {
          const x = graphviz(ref.current).dot(graphString);
          console.log({ x });
          x.render();
        }
      } catch (error) {}
    }, [graphString]);
    return React.createElement("svg", { width: 400, height: 200, ref });
  };
};
