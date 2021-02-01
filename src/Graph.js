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
  console.log({ graph });
  graph.nodes.forEach((node) => {
    g.setNode(node.key, {
      // label: node.label,
      label: `
        <h3>${node.label}</h3>
        <p>Hello this is a description
        ${(node.label + " and ").repeat(5) + "what."}</p>
      `,
      labelType: "html",
      labelStyle: "font-size: 1rem",
      // description: "This is a description",
    });
  });
  graph.edges.forEach((edge) => {
    // g.setEdge(edge.from, edge.to, {
    //   curve: d3.curveBasis,
    // });
    // console.log({ edge });
    g.setEdge(edge.from, edge.to, {});
  });

  // Create the renderer
  const render = new dagreD3.render();

  // Set up an SVG group so that we can translate the final graph.
  const svg = d3.select("svg"),
    inner = svg.append("g");

  // console.log({ svg });

  // Run the renderer. This is what draws the final graph.
  render(inner, g);

  // Center the graph
  const xCenterOffset = (svg.attr("width") - g.graph().width) / 2;
  inner.attr("transform", "translate(" + xCenterOffset + ", 20)");
  svg.attr("height", g.graph().height + 40);
};

// // Create the input graph
//

// // Fill node "A" with the color green
// g.setNode("A", { style: "fill: #afa" });

// // Make the label for node "B" bold
// g.setNode("B", { labelStyle: "font-weight: bold" });

// // Double the size of the font for node "C"
// g.setNode("C", { labelStyle: "font-size: 2em" });

// g.setNode("D", {});

// g.setNode("E", {});

// // Make the edge from "A" to "B" red, thick, and dashed
// g.setEdge("A", "B", {
//   style: "stroke: #f66; stroke-width: 3px; stroke-dasharray: 5, 5;",
//   arrowheadStyle: "fill: #f66"
// });

// // Make the label for the edge from "C" to "B" italic and underlined
// g.setEdge("C", "B", {
//   label: "A to C",
//   labelStyle: "font-style: italic; text-decoration: underline;"
// });

// // Make the edge between A and D smoother.
// // see available options for lineInterpolate here: https://github.com/mbostock/d3/wiki/SVG-Shapes#line_interpolate
// g.setEdge("A", "D", {
//   label: "line interpolation different",
//   curve: d3.curveBasis
// });

// g.setEdge("E", "D", {});

// // Make the arrowhead blue
// g.setEdge("A", "E", {
//   label: "Arrowhead class",
//   arrowheadClass: 'arrowhead'
// });

// // Create the renderer
// var render = new dagreD3.render();

// // Set up an SVG group so that we can translate the final graph.
// var svg = d3.select("svg"),
//     inner = svg.append("g");

// // Run the renderer. This is what draws the final graph.
// render(inner, g);

// // Center the graph
// var xCenterOffset = (svg.attr("width") - g.graph().width) / 2;
// inner.attr("transform", "translate(" + xCenterOffset + ", 20)");
// svg.attr("height", g.graph().height + 40);
