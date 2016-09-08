local ffi = require("ffi")

ffi.cdef[[
typedef long int time_t;
enum fsw_event_flag
{
	NoOp = 0,                     /**< No event has occurred. */
	PlatformSpecific = (1 << 0),  /**< Platform-specific placeholder for event type that cannot currently be mapped. */
	Created = (1 << 1),           /**< An object was created. */
	Updated = (1 << 2),           /**< An object was updated. */
	Removed = (1 << 3),           /**< An object was removed. */
	Renamed = (1 << 4),           /**< An object was renamed. */
	OwnerModified = (1 << 5),     /**< The owner of an object was modified. */
	AttributeModified = (1 << 6), /**< The attributes of an object were modified. */
	MovedFrom = (1 << 7),         /**< An object was moved from this location. */
	MovedTo = (1 << 8),           /**< An object was moved to this location. */
	IsFile = (1 << 9),            /**< The object is a file. */
	IsDir = (1 << 10),            /**< The object is a directory. */
	IsSymLink = (1 << 11),        /**< The object is a symbolic link. */
	Link = (1 << 12),             /**< The link count of an object has changed. */
	Overflow = (1 << 13)          /**< The event queue has overflowed. */
};
typedef struct fsw_cevent
{
	char * path;
	time_t evt_time;
	enum fsw_event_flag * flags;
	unsigned int flags_num;
} fsw_cevent;
enum fsw_monitor_type
{
	system_default_monitor_type = 0, /**< System default monitor. */
	fsevents_monitor_type,           /**< OS X FSEvents monitor. */
	kqueue_monitor_type,             /**< BSD `kqueue` monitor. */
	inotify_monitor_type,            /**< Linux `inotify` monitor. */
	windows_monitor_type,            /**< Windows monitor. */
	poll_monitor_type,               /**< `stat()`-based poll monitor. */
	fen_monitor_type                 /**< Solaris/Illumos monitor. */
};
typedef void (*FSW_CEVENT_CALLBACK)(fsw_cevent const *const events, const unsigned int event_num, void *data);
typedef int FSW_STATUS;
unsigned int sleep(unsigned int seconds);
FSW_STATUS fsw_init_library();
typedef int FSW_STATUS;
typedef unsigned int FSW_HANDLE;
FSW_HANDLE fsw_init_session(const enum fsw_monitor_type);
FSW_STATUS fsw_add_path(const FSW_HANDLE handle, const char * path);
FSW_STATUS fsw_set_callback(const FSW_HANDLE handle, const FSW_CEVENT_CALLBACK callback, void * data);
FSW_STATUS fsw_start_monitor(const FSW_HANDLE handle);
FSW_STATUS fsw_destroy_session(const FSW_HANDLE handle); 
]]
local Fswatch = {
  eventFlags = {
    [0] = "NoOp",                             -- No event has occurred. */
    [bit.lshift(1, 0)] = "PlatformSpecific",  -- Platform-specific placeholder for event type that cannot currently be mapped. */
    [bit.lshift(1, 1)] = "Created",           -- An object was created. */
    [bit.lshift(1, 2)] = "Updated",           -- An object was updated. */
    [bit.lshift(1, 3)] = "Removed",           -- An object was removed. */
    [bit.lshift(1, 4)] = "Renamed",           -- An object was renamed. */
    [bit.lshift(1, 5)] = "OwnerModified",     -- The owner of an object was modified. */
    [bit.lshift(1, 6)] = "AttributeModified", -- The attributes of an object were modified. */
    [bit.lshift(1, 7)] = "MovedFrom",         -- An object was moved from this location. */
    [bit.lshift(1, 8)] = "MovedTo",           -- An object was moved to this location. */
    [bit.lshift(1, 9)] = "IsFile",            -- The object is a file. */
    [bit.lshift(1, 10)] = "IsDir",            -- The object is a directory. */
    [bit.lshift(1, 11)] = "IsSymLink",        -- The object is a symbolic link. */
    [bit.lshift(1, 12)] = "Link",             -- The link count of an object has changed. */
    [bit.lshift(1, 13)] = "Overflow"          -- The event queue has overflowed. */
  }
}
Fswatch.__index = Fswatch

function Fswatch.new(self, o) 
  o = o or {}
  setmetatable(o, Fswatch)
  o.libfswatch = ffi.load("libfswatch")
  self.__index = self
  o.libfswatch.fsw_init_library()
  o.handle =  o.libfswatch.fsw_init_session(o.libfswatch.system_default_monitor_type)
  return o 
end
function Fswatch.add_path(self, path) 
  return self.libfswatch.fsw_add_path(self.handle, path)
end
function Fswatch.set_callback(self, callback, context) 
  return self.libfswatch.fsw_set_callback(self.handle, callback, context)
end
function Fswatch.start_monitor(self) 
  return self.libfswatch.fsw_start_monitor(self.handle)
end
function Fswatch.__gc(self) 
  self.libfswatch.fsw_destroy_session(self.handle)
end
return Fswatch 
