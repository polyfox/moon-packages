```ruby
#+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
#  Entity System proposal
#------------------------------------------------------------------------------
#  * Serialization interface
#    In order for a custom class to be serializable, it needs to define
#    to_h, export, import(data), self.load(data).
#
#  * Entity is just a uuid, that's used for identifying components.
#    In our case, it's wrapped into an object, with a few accessors to make
#    the syntax nicer. It stores no state whatsoever, besides being tied to
#    a particular world object (in order to do lookup).
#
#  * Component is a data bag.
#    It stores state about a specific property. We've created a mixin that
#    gets included into any component class, that provides the serialization
#    interface, plus a simple way to define "fields" -- ivars with accessors,
#    type checking and default values.
#
#  * System is the main logic processor.
#    It operates on specific component types (grouped per entity), and it
#    applies transformations to data. It can run every tick, or it can be async
#    and triggered when needed, or in response to some event.
#
#    Systems are usually modules. We've provided a System mixin, that defines
#    the import/export interface.
#
#  * World is our entity manager.
#    It ties all of the other parts together, and it contains the main component
#    tree, connecting entities to components.
#
#---- TODO --------------------------------------------------------------------
#  - ability to fetch entities by specific queries?
#  - make systems parallelized
#  - make inheritance and initialization easier for Components (no setup())
#  - type checking on variables
#  - (AR style validations?)
#+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=+=
```
