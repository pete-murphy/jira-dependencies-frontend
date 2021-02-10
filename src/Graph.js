const dagreD3 = require("dagre-d3");
const d3 = require("d3");

// graph :: Graph
// graph =
//   { nodes:
//       [ { label: "Label"
//         , key: NodeKey "A"
//         }
//       ]
//   , edges:
//       [ { to:
//             NodeKey "B"
//         , from:
//             NodeKey "A"
//         }
//       ]
//   }

exports._makeGraph = (graph) => () => {
  const g = new dagreD3.graphlib.Graph().setGraph({});
  graph.nodes.forEach((node) => {
    g.setNode(node.key, {
      label: `
        <h3>${node.label}</h3>
        <p>${node.label}<p>
      `,
      labelType: "html",
      labelStyle: "font-size: 1rem",
    });
  });
  graph.edges.forEach((edge) => {
    g.setEdge(edge.from, edge.to, {
      curve: d3.curveBasis,
    });
  });

  // Create the renderer
  const render = new dagreD3.render();

  // console.log("layout", dagreD3.intersect);

  // Set up an SVG group so that we can translate the final graph.
  const svg = d3.select("svg");
  const inner = svg.append("g");

  // console.log({ svg });

  // Run the renderer. This is what draws the final graph.
  render(inner, g);

  // @TODO - Pete Murphy 2021-02-03 - Need to actually render the graph in order
  // to extract the attributes out of it
  console.log(2, { g });
  console.log(
    3,
    Object.values(g._nodes).map(({ elem }) =>
      [...elem.firstChild.attributes].map((attr) => [attr.name, attr.value])
    )
  );

  // Center the graph
  // const xCenterOffset = (svg.attr("width") - g.graph().width) / 2;
  // inner.attr("transform", "translate(" + xCenterOffset + ", 20)");
  // svg.attr("height", g.graph().height + 40);
};
