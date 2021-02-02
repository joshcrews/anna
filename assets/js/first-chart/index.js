import React from "react";
import { render } from "react-dom";
import { compose, createStore, combineReducers, applyMiddleware } from "redux";
import { Provider } from "react-redux";
import { devTools } from "redux-devtools";
import thunk from "redux-thunk";
import chartApp from "./reducers";
import App from "./Containers/App";


const initial_state = {}

const store = createStore(
  chartApp,
  initial_state,
  compose(
    applyMiddleware(thunk),
    window.devToolsExtension ? window.devToolsExtension() : (f) => f
  )
);

render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById("first-chart-react")
);
