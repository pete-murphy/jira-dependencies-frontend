const React = require("react");
const { graphviz } = require("d3-graphviz");

const _ = graphviz;
_;

exports._mkGraph = function () {
  return function ({ graphString }) {
    const ref = React.useRef(null);
    const [{ vw, vh }, setViewport] = React.useState({ vw: 0, vh: 0 });
    React.useEffect(() => {
      const updateViewport = () => {
        const vw = Math.max(
          document.documentElement.clientWidth || 0,
          window.innerWidth || 0
        );
        const vh = Math.max(
          document.documentElement.clientHeight || 0,
          window.innerHeight || 0
        );
        console.log({ vw, vh });
        setViewport({ vw, vh });
      };
      updateViewport();
      window.addEventListener("resize", updateViewport);
      return () => window.removeEventListener("resize", updateViewport);
    }, []);
    React.useEffect(() => {
      console.log({ graphString });
      try {
        if (ref && graphString) {
          graphviz(ref.current).dot(graphString).render();
        }
      } catch (error) {}
    }, [graphString]);
    return React.createElement("div", {
      id: "graph-container",
      width: vw,
      height: vh,
      ref,
    });
  };
};
