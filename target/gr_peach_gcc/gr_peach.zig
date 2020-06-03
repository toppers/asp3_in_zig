///
///  GR-PEACHのハードウェア資源の定義
///

///
///  RZ/A1のハードウェア資源の定義
///
const rza1 = @import("../../arch/arm_gcc/rza1/rza1.zig");

///
///  各クロック周波数の定義
///
pub const RZA1_CLK_I     = 400000000;   // 400MHz
pub const RZA1_CLK_I_MHZ = 400;         // 400MHz
pub const RZA1_CLK_G     = 266666667;   // 266.66…MHz
pub const RZA1_CLK_B     = 133333333;   // 133.33…MHz
pub const RZA1_CLK_P1    = 66666667;    // 66.66…MHz
pub const RZA1_CLK_P0    = 33333333;    // 33.33…MHz

///
///  LEDの点灯／消灯
///
pub const LED_RED   = 13;
pub const LED_GREEN = 14;
pub const LED_BLUE  = 15;
pub const LED_USER  = 12;

pub fn set_led(led: u4, set: bool) void {
    rza1.config_port(rza1.RZA1_PORT_P(6), led, set);
}
