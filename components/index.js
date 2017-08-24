import React, { Component } from 'react'
import PropTypes from 'prop-types';

import {
  requireNativeComponent,
  NativeModules,
  findNodeHandle,
  processColor
} from 'react-native'

const Canvas = requireNativeComponent('Canvas', CanvasView);

export default class CanvasView extends Component {
  getSnapshot = () => {
    const snapshot = NativeModules.ViewSnapshot;
    const viewId = findNodeHandle(this.view);
    return snapshot.getSnapshot(viewId);
  }

  render () {
    const { documentName, paths, ...props } = this.props;

    const parsedPaths = paths.map(path => ({
      ...path,
      color: processColor(path.color)
    }));

    return (
      <Canvas
        ref={canvas => (this.view = canvas)}
        {...props}
        paths={parsedPaths}
      />
    )
  }
}

CanvasView.propTypes = {
  strokeWidth: PropTypes.number,
  color: PropTypes.string,
};
