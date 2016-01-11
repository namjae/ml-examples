defmodule TrainingSet do
  defstruct x: [], y: []

  @doc """
  Creates new TrainingSet from input list which is a list of two list elements x and y
  x is a list of lists and represents a features matrix
  y is a list (vector) of feature measurements
  """
  def new([x, y]) do
    %TrainingSet{x: x, y: y}
  end

  @doc """
  Loads training set data from a CSV file in format x1,x2,..,xn,y
  Returns TrainingSet initialized with data loaded from the data file
  """
  def load_from_file(path) do
    File.stream!(path)
    |> parse_line
    |> vectorize_line
    |> generate_x_y
    |> TrainingSet.new
  end

  @doc """
  parse_line removes EOL character from the read line string then splits it by "," character
  into a list and finally converts each element of the resulting list from string to float number
  ["2104", "3", "399900"] -> [2104.0, 3.0, 3.999e5]
  """
  defp parse_line(line) do
    line
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Stream.map(&String.split(&1, ",", trim: true))
    |> Stream.map(&List.foldr(&1, [],
      fn(x, acc) ->
        [String.to_integer(x)/1.0 | acc]
      end)
    )
  end

  @doc """
  vectorize_line transforms [x1,..,xn, y] into [[x1,...,xn], [y]]
  it basically separates particular feature matrix row from its measurements
  """
  defp vectorize_line(line) do
    line
    |> Stream.map(
      &List.foldr(&1, [[]], 
        fn(row_el, [x | y]) ->
          case length(y) do
            # measurment vector y
            0 -> [[], row_el]
            # should be ok to List.flatten as y only has 1 element
            _ -> [[row_el | x], List.flatten(y)]
          end
      end)
    )
  end

  @doc """
  generate_x_y turns a list of [[[xi...],[yi]], ...] into [[x],[y]] where
  x is a features matrix and y is a features measurement vector
  """
  defp generate_x_y(data) do
    data
    |> Enum.reduce([[]],
      fn([x, y], [x_acc | y_acc]) ->
        [y | _] = y
        # should be ok List.flatten here as y_acc only has one element
        [[x | x_acc], [y | List.flatten(y_acc)]]
    end)
    |> reverse_x_y
  end

  @doc """
  reverse_x_y reverses every row of matrix x and vector y so it's
  in the same order as it is present in the training set data file
  """
  defp reverse_x_y([x, y]) do
    [Enum.reverse(x), Enum.reverse(y)]
  end
end
