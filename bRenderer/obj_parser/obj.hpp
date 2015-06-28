#ifndef OBJ_OBJ_HPP_INCLUDED
#define OBJ_OBJ_HPP_INCLUDED

#include <cstddef>
#include <boost/tuple/tuple.hpp>

namespace obj {
    
typedef std::size_t size_type;
typedef std::ptrdiff_t index_type;
typedef double float_type;
typedef boost::tuple<index_type, index_type> index_2_tuple_type;
typedef boost::tuple<index_type, index_type, index_type> index_3_tuple_type;

} // namespace obj

#endif // OBJ_OBJ_HPP_INCLUDED