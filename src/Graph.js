const React = require("react");
const { graphviz } = require("d3-graphviz");

// const _ = graphviz;
// _;

exports._mkGraph = function () {
  return function ({ graphString }) {
    const ref = React.useRef(null);
    React.useEffect(() => {
      try {
        if (ref && graphString) {
          graphviz(ref.current).dot(graphString).render();
        }
      } catch (error) {}
    }, [graphString]);
    return React.createElement("div", {
      id: "graph-container",
      ref,
    });
  };
};
