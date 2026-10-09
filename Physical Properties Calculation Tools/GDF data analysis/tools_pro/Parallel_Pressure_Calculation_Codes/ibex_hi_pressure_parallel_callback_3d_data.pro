pro ibex_hi_pressure_parallel_callback_3d_data, status, error, ibex_hi_pressure_auto_bridge, pressure_calc_result

  tmp_pressure       = ibex_hi_pressure_auto_bridge->getvar('pressure')
  tmp_pressure_sigma = ibex_hi_pressure_auto_bridge->getvar('pressure_sigma')

  (*(pressure_calc_result.pressure))       [pressure_calc_result.angle_loop, pressure_calc_result.angle_loop1,*] = tmp_pressure
  (*(pressure_calc_result.pressure_sigma)) [pressure_calc_result.angle_loop, pressure_calc_result.angle_loop1,*] = tmp_pressure_sigma

end