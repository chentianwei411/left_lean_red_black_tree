class Node
  attr_accessor :item, :color, :left, :right, :key

  def initialize(key, item = "enter any data")
    @key = key
    @item = item
    @color = :red                         # 节点的颜色默认为红色
    @left = nil
    @right = nil
  end
end

class RedBlackTree
  attr_reader :root, :length

  def initialize
    @root = nil
    @length = 0
  end

  def insert(key, item)               # 红黑树的插入操作
    @root = _insert(@root, key, item)
    @root.color = :black              # 无论如何调整，根节点的颜色根据定义永远是黑色
  end

  def inorder_tree_walk(node)
    if node.left != nil
      inorder_tree_walk(node.left)
    end
    p node.key
    if node.right != nil
      inorder_tree_walk(node.right)
    end
  end

  # 查找
  def include?(node = self.root, number)
    if node.key > number && node.left != nil
      include?(node.left, number)
    elsif node.key < number && node.right != nil
      include?(node.right, number)
    elsif node.key == number
      return true
    else
      return false
    end
  end

  def delete_max
    # 只有root节点的情况：
    if @root.right == nil && @root.left == nil
      @root = nil
      return puts "delete root node, then tree is nil"
    end
    @root = _delete_max(@root)
    @root.color = :black
  end

  def delete_min
    if @root.right == nil && @root.left == nil
      @root = nil
      return puts "delete root node, then tree is nil"
    end
    @root = _delete_min(@root)
    @root.color = :black
  end

  def delete(k)
    @root = _delete(@root, k)
    @root.color = :black
  end

  def min(node)
    if node.left != nil
      min(node.left)
    else
      return node
    end
  end

  private

    def _delete(node, k)
      if self.root == nil
        return nil
      end
      #删除节点在左子树。left
      if node.key > k
        if !is_red?(node.left) && !is_red?(node.left.left)
          node = move_red_left(node)
        end
        node.left = _delete(node.left, k)
      # 删除节点在右子树。 或是节点本身。
      else
        # 类似删除最大值：
        if is_red?(node.left)
          node = rotate_right(node)
        end
        # 在树底部，找到要删除的节点。删除它，返回nil。
        if node.right == nil && node.key == k
          return nil
        end
        # 当前节点的右节点不是双key节点的话，就需要借用了。
        if !is_red?(node.right) && !is_red?(node.right.left)
          node = move_red_right(node)
        end
        # 在树中间层找到要删除的节点。需要转化：
        # 思考？
        # 结论：2-3树删除中间层的节点的方法同样适用于这里：
        # 找到要删除节点x的中序列遍历的后续节点next_node,它一定在底层，交换两者。然后删除x。
        # 考虑红黑树的代码：
        # 1.node右子树的最小值即它的后续节点next_node。
        # 2.把next_node的key和item（即储存的内容）复制给节点x。那么节点x就被替换掉了。相当于x被删除了。
        # 3.最后删除在底部的重复的后续节点next_node。
        if node.key == k
          next_node = min(node.right)
          node.key = next_node.key
          # node.item = next_node.item
          # ⚠️：删除使用私有方法
          node.right = _delete_min(node.right)
        else
        #没有找到要删除节点，则移动到下一层：
          node.right = _delete(node.right, k)
        end
      end

      return fix_up(node)
    end

    def _delete_min(node)
      if node.left == nil
        if @length > 0
          @length -= 1
        end
        return nil
      end

      if !is_red?(node.left) && !is_red?(node.left.left)
        node = move_red_left(node)
      end

      node.left = _delete_min(node.left)

      return fix_up(node)
    end

    def _delete_max(node)
      # 相当于把双key节点的较大值准备借出。
      if is_red?(node.left)
        node = rotate_right(node)
      end
      # 节点的right是nil，则判断为最大节点，返回nil
      if node.right == nil
        # 树节点总数减1.
        if @length > 0
          @length -= 1
        end
        return nil
      end

      # 从2-3树来看，当前节点的右节点不是双key节点的话，就需要借用了。
      if !is_red?(node.right) && !is_red?(node.right.left)
        node = move_red_right(node)
      end
      #继续移动到下一层：
      node.right = _delete_max(node.right)
      #删除完后需要，从下向上修复左倾红黑树结构。
      return fix_up(node)
    end

    def move_red_left(node)
      flip_color(node)
      if is_red?(node.right.left)
        node.right = rotate_right(node.right)
        node = rotate_left(node)
        flip_color(node)
      end
      return node
    end

    def move_red_right(node)
      #借用有2种：即node。left.left是否是红的。
      flip_color(node)
      if is_red?(node.left.left)
        node = rotate_right(node)
        flip_color(node)
      end
      return node
    end

  # 因为每个节点和其左右子树都是一个二叉搜索树，所以使用递归的方法对插入的节点的key进行比较。
  # 当完成插入节点，对树进行再平衡。然后递归回退到上一个节点，继续再平衡，直到结束。
    def _insert(node, key, item)
      if node == nil
        @length += 1
        return Node.new(key, item)
      end

      if key < node.key
        node.left = _insert(node.left, key, item)
      elsif key > node.key
        node.right = _insert(node.right, key, item)
      end

      return fix_up(node)             # 用fix_up方法来保持红黑树的平衡
    end

    #左倾红黑树的三种调整方式：左旋，右旋，上传颜色。
    def fix_up(n)
      n = rotate_left(n) if is_red?(n.right)
      n = rotate_right(n) if is_red?(n.left) && is_red?(n.left.left)
      n = flip_color(n) if is_red?(n.left) && is_red?(n.right)
      return n
    end

    def rotate_left(n)                     # 左旋：旋转new_node的父节点n，变为new_node的左儿子。
      new_node = n.right
      n.right = new_node.left
      new_node.left = n
      new_node.color = new_node.left.color
      new_node.left.color = :red
      return new_node
    end

    def rotate_right(n)                    # 右旋一个节点
      n_l = n.left
      # 如果n_l有右儿子的话，需要重新调整位置。
      n.left = n_l.right
      n_l.right = n
      #调整后，改颜色
      n_l.color = n_l.right.color
      n_l.right.color = :red
      return n_l
    end

    def flip_color(n)                      # 将红色向上传递或下降
      n.color = n.color == :red ? :black : :red
      n.left.color = n.left.color == :red ? :black : :red
      n.right.color = n.right.color == :red ? :black : :red
      return n
    end

    def is_red?(n)
      return n != nil && n.color == :red
    end
end

# 建立一颗树：
# tree = RedBlackTree.new()
# tree.insert(0, "a")
# # 给树插入节点：
# [1,2,3,4,-1,-2].map { |e| tree.insert(e, "aa")  }
# #中序遍历
# tree.inorder_tree_walk(tree.root)
# p tree.include?(-1)
#
# 6.times do |x|
#   puts "第#{x + 1}删除："
#   tree.delete_min
#   tree.inorder_tree_walk(tree.root)
# end
# puts "删除只有根节点的tree:"
# tree.delete_min

tree2 = RedBlackTree.new()
tree2.insert(0, 'a')
[1,2,3,4,5,6,7,8,9].map { |e| tree2.insert(e, 'aa')  }
# 3.times do |x|
#   puts "第#{x + 1} 次："
#   tree2.delete_min
#   tree2.inorder_tree_walk(tree2.root)
# end
tree2.inorder_tree_walk(tree2.root)
tree2.delete(8)
puts "Tree:"
tree2.inorder_tree_walk(tree2.root)
