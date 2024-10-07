{...}: {
  programs.bottom = {
    enable = true;
    settings = {
      colors = {
        table_header_color = "#8aadf4";
        all_cpu_color = "#ed8796";
        avg_cpu_color = "#eed49f";
        cpu_core_colors = ["#a6da95" "#8aadf4" "#f5bde6" "#f5a97f"];
        ram_color = "#8aadf4";
        swap_color = "#f5bde6";
        rx_color = "#a6da95";
        tx_color = "#ed8796";
        widget_title_color = "#cad3f5";
        border_color = "#494d64";
        highlighted_border_color = "#8aadf4";
        text_color = "#cad3f5";
        graph_color = "#a6da95";
        cursor_color = "#f5bde6";
        selected_text_color = "#24273a";
        selected_bg_color = "#8aadf4";
        high_battery_color = "#a6da95";
        medium_battery_color = "#eed49f";
        low_battery_color = "#ed8796";
        gpu_core_colors = ["#8aadf4" "#a6da95" "#eed49f" "#ed8796"];
        arc_color = "#91d7e3";
      };
    };
  };
}
