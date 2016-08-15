defmodule CsvWatcher.FileWatcher do
	use GenServer

	## Public API
	def start_link(path) do
		GenServer.start_link(__MODULE__, [path], [])
	end

	def init(path) do
		send(self, :fetch)
		{:ok, { path, Timex.now }}
	end

	def handle_info(:fetch, state={ path, last_time }) do
		fetch_and_decode(path) |>
			process_and_send

		:timer.send_after(1_000, :fetch)
		{:noreply, state}
	end

	defp fetch_and_decode(path) do
		File.stream!(path) |>
			CSV.decode(separator: ?;, headers: true, drop_rows: 2)
	end

	defp process_and_send(row) do
		Enum.each(row, fn r ->
			CsvHandler.Handler.handle(r)
		end)
	end

end
