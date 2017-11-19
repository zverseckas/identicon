defmodule Identicon do
  alias Identicon.Image

  def generate(input) do
    input
    |> hash_input
    |> pick_colour
    |> build_grid
    |> filter_odd
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def hash_input(input) do
    %Image{seed: :crypto.hash(:md5, input) |> :binary.bin_to_list}
  end

  def pick_colour(%Image{seed: [r, g, b | _tail]} = image) do
    %Image{image | colour: {r, g, b}}
  end

  def build_grid(%Image{seed: seed} = image) do
    grid =
      seed
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index
    
    %Image{image | grid: grid}
  end

  def filter_odd(%Image{grid: grid} = image) do
    grid = Enum.filter grid, fn ({code, _index}) -> rem(code, 2) == 0 end
    %Image{image | grid: grid}
  end

  def build_pixel_map(%Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_code, index}) ->
      horz = rem(index, 5) * 50
      vert = div(index, 5) * 50
      {{horz, vert},{horz + 50, vert + 50}}
    end

    %Image{image| pixel_map: pixel_map}
  end

  def draw_image(%Image{colour: colour, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill  = :egd.color(colour)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def save_image(binary, file_name) do
    File.write("img/#{file_name}.png", binary)
  end

  def mirror_row([fst, snd | _tail] = row) do
    row ++ [snd, fst]
  end
end
