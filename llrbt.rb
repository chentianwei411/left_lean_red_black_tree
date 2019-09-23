class Node
  attr_accessor :item, :color, :left, :right
  attr_reader :key

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

  private
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

    def move_red_left(node)
      flip_color(node)
      if is_red?(node.right.left)
        node.right = rotate_right(node.right)
        node = rotate_left(node)
        flip_color(node)
      end
      return node
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

      # 重2-3树来看，当前节点的右节点不是双key节点的话，就需要借用了。
      if !is_red?(node.right) && !is_red?(node.right.left)
        node = move_red_right(node)
      end
      #继续移动到下一层：
      node.right = _delete_max(node.right)
      #删除完后需要，从下向上修复左倾红黑树结构。
      return fix_up(node)
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
tree = RedBlackTree.new()
tree.insert(0, "a")
# 给树插入节点：
[1,2,3,4,-1,-2].map { |e| tree.insert(e, "aa")  }
#中序遍历
tree.inorder_tree_walk(tree.root)
p tree.include?(-1)

6.times do |x|
  puts "第#{x + 1}删除："
  tree.delete_min
  tree.inorder_tree_walk(tree.root)
end
puts "删除只有根节点的tree:"
tree.delete_min
