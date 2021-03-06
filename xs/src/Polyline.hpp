#ifndef slic3r_Polyline_hpp_
#define slic3r_Polyline_hpp_

#include "Line.hpp"
#include "MultiPoint.hpp"

namespace Slic3r {

class Polyline : public MultiPoint {
    public:
    Point* last_point() const;
    Lines lines() const;
    void clip_end(double distance);
    void clip_start(double distance);
    Points equally_spaced_points(double distance) const;
    
    #ifdef SLIC3RXS
    void from_SV_check(SV* poly_sv);
    SV* to_SV_ref();
    SV* to_SV_clone_ref() const;
    #endif
};

typedef std::vector<Polyline> Polylines;

}

#endif
