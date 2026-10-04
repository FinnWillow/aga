var middle = (bbox_top + bbox_bottom) / 2;
if (other.y < middle) {
    other.draw_level = upper_level;
} else {
    other.draw_level = lower_level;
}