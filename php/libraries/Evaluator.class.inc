<?php
/**
 * This file parses LORIS Parser syntax and returns an evaluated result
 * using AST nodes
 *
 * PHP Version 7
 *
 * @category Main
 * @package  Loris
 * @author   Zain Virani <zvirani.mcin@gmail.com>
 * @license  http://www.gnu.org/licenses/gpl-3.0.txt GPLv3
 * @link     https://www.github.com/aces/Loris-Trunk/
 */

namespace LorisScript;
require_once "Functions.php";


/**
 * Functions can be added in the Functions.php file
 * I seriously recommend you don't edit this unless
 * you know what you're doing. Mathematical syntax doesn't change.
 * - ZV
 *
 * @category Main
 * @package  Loris
 * @author   Zain Virani <zvirani.mcin@gmail.com>
 * @license  http://www.gnu.org/licenses/gpl-3.0.txt GPLv3
 * @link     https://www.github.com/aces/Loris-Trunk/
 */
class Evaluator
{
    /**
     * Recursively evaluates a single node of the tree
     *
     * @param Parser $tree  the AST tree
     * @param array  $scope an array of values to be used in the expression
     *
     * @return mixed
     */
    static function evalAST($tree, $scope)
    {
        $FUNCTIONS  = getFunctions();
        $UNARY_OPS  = getUnary();
        $BINARY_OPS = getBinary();

        $evalarg = function ($a) use ($scope) {
            return static::evalAST($a, $scope);
        };
            $constants = array(
                          'E'     => exp(1),
                          'PI'    => pi(),
                          'false' => false,
                          'true'  => true,
                          'null'  => null,
                         );
            switch($tree['tag']) {
            case 'String':
            case 'EString':
                return substr((string)$tree['args'][0], 1, -1);
            case 'Number':
                return floatval($tree['args'][0]);
            case 'Constant':
                return $constants[$tree['args'][0]];
            case 'Variable':
                if (isset($scope[$tree['args'][0]])) {
                    return $scope[$tree['args'][0]];
                }
                throw new \Exception("Unbound variable: " . $tree['args'][0]);
            case 'NestedVariable':
                if (isset($scope[$tree['args'][0]])) {
                    $res = $scope[$tree['args'][0]];
                    $i   = 0;
                    for ($i; $i < count($tree['args'][1]); $i++) {
                        if (!isset($res[$tree['args'][1][$i]])) {
                            throw new \Exception(
                                "Unbound sub-variable: "
                                .$tree['args'][1][$i]
                            );
                        }
                        $res = $res[$tree['args'][1][$i]];
                    }
                    return $res;
                }
                throw new \Exception("Unbound variable: " . $tree['args'][0]);
            case 'FuncApplication':
                if ($tree['args'][0] == 'if') {
                    if (static::evalAST($tree['args'][1][0], $scope)) {
                        return static::evalAST($tree['args'][1][1], $scope);
                    }
                    return static::evalAST($tree['args'][1][2], $scope);
                }
                $funcName = '_'.$tree['args'][0];
                if (!isset($FUNCTIONS[$funcName])) {
                    throw new \Exception(
                        `{$tree['args'][0]}`.
                        ` is not a defined function.`
                    );
                }
                $funcArgs = array_map($evalarg, $tree['args'][1]);
                return $FUNCTIONS[$funcName](...$funcArgs);
            case 'NestedExpression':
                return static::evalAST($tree['args'][0], $scope);
            case 'UnaryOp':
                $funcName = '_'.$tree['op'];
                return $UNARY_OPS[$funcName](static::evalAST(
                    $tree['args'][0],
                    $scope
                ));
            case 'BinaryOp':
                $funcArgs = array_map($evalarg, $tree['args']);
                $funcName = '_'.$tree['op'];
                return $BINARY_OPS[$funcName](...$funcArgs);
            }
    }

    /**
     * Evaluates an expression with scope using an AST
     *
     * @param string $expression a mathematical expression
     * @param array  $scope      a set of values to be used by evalAST
     *
     * @return mixed
     */
    static function evaluate($expression, $scope)
    {
        //error_log("Evaluating $expression");
        if (!isset($expression)) {
            return null;
        }
        if ($expression === '' || preg_match('/\A\s*\z/', $expression)) {
            return '';
        }
        try {
            $tree = (new Parser($expression))->parse();
        } catch (\Exception $e) {
            throw new \Exception("Parser error; review Syntax\n$e");
        }
        $res = static::evalAST($tree, $scope);
        return $res;
    }
}

    // For testing:
    // php evaluator.php 'eq([x][z(0)], 33)'
    // var_dump(Evaluator::evaluate($argv[1], array('x' => array('z' => 33))));
?>
