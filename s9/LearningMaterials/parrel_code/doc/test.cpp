/**
 * @file   test.cpp
 * @author Robert Lie
 * @date   Wed Apr 13 20:25:12 2005
 * 
 * @brief  这个例子主要是为了列举一下 Doxygen 要求的注释的格式，
 *         这里读者可以写下关于该文件的简要说明
 * 
 */

int n; /**< 这是一个全局变量 */

/** 
 * 这是一个函数的注释方式，可以在注释中加入用 TeX 格式书写
 * 的数学公式，比如嵌在行内的数学公式 \f$ \alpha^2 + \beta^2 \f$，
 * 公式前后分别用字符串 "\f$" 括起来。也可以写居中对齐的数学公式，例如
 * \f[ 
 *   \int_\Omega \nabla u \cdot \nabla v dx = \int_\Omega f v dx 
 * \f]
 * 这里，"\f[" 表示一个居中对齐的公式。
 * 
 * @param x 对函数参数的注释
 * @param y 另外一个参数的注释
 * 
 * @return 函数的返回值的注释
 */
double f(double x，double y);

/**
 * @brief 这是对一个类的注释方式。可以在这里先写一个摘要
 *
 * 然后，在这里详细描述这个类的具体功用，实现技术等内容。在注释中
 * 还可以使用 HTML 语言，产生灵活的 HTML 格式的文档。例如，
 * 可以加入一个到<a href=\"http://www.pku.edu.cn\">北京大学</a>的
 * 链接，在产生的文档中，就会出现一个相应的链接。至于具体哪些 HTML
 * 的命令可在 Doxygen 中使用请参考其文档。也可以非常方便地产生列表：
 *   - 列表的第一条；
 *   - 列表的第二条；
 * 上面两行将被格式化为列表。Doxygen 会自动分析所有的类之间的相互
 * 继承关系，从而自动生成类的继承关系图表。
 *
 */
class C : public base
{
 private:
  /**
   * @defgroup Coord 坐标
   * 对于内容联系在一起的一些变量或者函数可以对它们统一写注释，
   * 下面就是一个这样的例子，其中先定义了一个组叫做 Coord
   */
  /*\@{*/
  /**
   * @addtogroup Coord
   * x，y 坐标变量
   */
  double x_;
  double y_;
  /*\@}*/
 public:
  /*\@{*/
  /**
   * @addtogroup Coord
   * x，y 坐标变量的只读获取函数
   */
  const double& x() const;
  const double& y() const;
  /*\@}*/
};
