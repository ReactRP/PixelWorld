//import webpack from 'webpack';
const webpack = require('webpack');
const path = require('path');

module.exports = {
    entry: './js/src/app.js',
    output: {
        path: path.resolve(__dirname, 'js'),
        publicPath: 'js/',
        filename: 'build.js'
    },
    mode: 'production',
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: [
                    path.resolve(__dirname, 'node_modules'),
                    path.resolve(__dirname, 'libs'),
                ],
                loader: 'babel-loader'
            },
            {
                // Preprocess our own .css files
                // This is the place to add your own loaders (e.g. sass/less etc.)
                // for a list of loaders, see https://webpack.js.org/loaders/#styling
                test: /\.scss$/,
                exclude: /node_modules/,
                use: ['style-loader', 'css-loader?url=false', 'sass-loader'],
            },
            {
                // Preprocess 3rd party .css files located in node_modules
                test: /\.css$/,
                include: /node_modules/,
                use: ['style-loader', 'css-loader'],
            },
            {
                test    : /\.(png|jpg|svg)$/,
                include : path.join(__dirname, 'imgs'),
                loader  : 'url-loader?limit=30000&name=images/[name].[ext]'
            },
        ]
    },
    devServer: {
        contentBase: __dirname,
        watchContentBase: true,
        port: 9000
    },
    performance: {
        hints: false,
        assetFilter: assetFilename =>
          !/(\.map$)|(^(main\.|favicon\.))/.test(assetFilename),
    }
};