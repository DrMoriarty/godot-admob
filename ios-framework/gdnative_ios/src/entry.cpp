#include <Godot.hpp>
#include "AdMob.hpp"

extern "C" void GDN_EXPORT admob_gdnative_init(godot_gdnative_init_options *o)
{
	godot::Godot::gdnative_init(o);
}

extern "C" void GDN_EXPORT admob_gdnative_terminate(godot_gdnative_terminate_options *o)
{
	godot::Godot::gdnative_terminate(o);
}

extern "C" void GDN_EXPORT admob_nativescript_init(void *handle)
{
	godot::Godot::nativescript_init(handle);


	godot::register_class<AdMob>();
}

extern "C" void GDN_EXPORT admob_gdnative_singleton()
{
}
