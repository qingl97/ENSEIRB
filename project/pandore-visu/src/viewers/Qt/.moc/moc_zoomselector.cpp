/****************************************************************************
** Meta object code from reading C++ file 'zoomselector.h'
**
** Created: Mon Feb 10 16:05:52 2014
**      by: The Qt Meta Object Compiler version 63 (Qt 4.8.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "../zoomselector.h"
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'zoomselector.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 63
#error "This file was generated using the moc from 4.8.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
static const uint qt_meta_data_ZoomSelector[] = {

 // content:
       6,       // revision
       0,       // classname
       0,    0, // classinfo
       3,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // signals: signature, parameters, type, tag, flags
      21,   14,   13,   13, 0x05,

 // slots: signature, parameters, type, tag, flags
      39,   36,   13,   13, 0x08,
      72,   62,   13,   13, 0x08,

       0        // eod
};

static const char qt_meta_stringdata_ZoomSelector[] = {
    "ZoomSelector\0\0factor\0newZoom(float)\0"
    "id\0zoomSelected(QAction*)\0increment\0"
    "keyZoom(bool)\0"
};

void ZoomSelector::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        Q_ASSERT(staticMetaObject.cast(_o));
        ZoomSelector *_t = static_cast<ZoomSelector *>(_o);
        switch (_id) {
        case 0: _t->newZoom((*reinterpret_cast< float(*)>(_a[1]))); break;
        case 1: _t->zoomSelected((*reinterpret_cast< QAction*(*)>(_a[1]))); break;
        case 2: _t->keyZoom((*reinterpret_cast< bool(*)>(_a[1]))); break;
        default: ;
        }
    }
}

const QMetaObjectExtraData ZoomSelector::staticMetaObjectExtraData = {
    0,  qt_static_metacall 
};

const QMetaObject ZoomSelector::staticMetaObject = {
    { &QMenu::staticMetaObject, qt_meta_stringdata_ZoomSelector,
      qt_meta_data_ZoomSelector, &staticMetaObjectExtraData }
};

#ifdef Q_NO_DATA_RELOCATION
const QMetaObject &ZoomSelector::getStaticMetaObject() { return staticMetaObject; }
#endif //Q_NO_DATA_RELOCATION

const QMetaObject *ZoomSelector::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->metaObject : &staticMetaObject;
}

void *ZoomSelector::qt_metacast(const char *_clname)
{
    if (!_clname) return 0;
    if (!strcmp(_clname, qt_meta_stringdata_ZoomSelector))
        return static_cast<void*>(const_cast< ZoomSelector*>(this));
    if (!strcmp(_clname, "Controller"))
        return static_cast< Controller*>(const_cast< ZoomSelector*>(this));
    return QMenu::qt_metacast(_clname);
}

int ZoomSelector::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QMenu::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 3)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 3;
    }
    return _id;
}

// SIGNAL 0
void ZoomSelector::newZoom(float _t1)
{
    void *_a[] = { 0, const_cast<void*>(reinterpret_cast<const void*>(&_t1)) };
    QMetaObject::activate(this, &staticMetaObject, 0, _a);
}
QT_END_MOC_NAMESPACE
